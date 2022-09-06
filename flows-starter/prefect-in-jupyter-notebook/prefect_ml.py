from ast import Str
from datetime import timedelta
from typing import Any, Dict, List

import pandas as pd
from pandas import DataFrame, Series
from prefect import flow, tags, task
from prefect.tasks import task_input_hash
from prefect_dask.task_runners import DaskTaskRunner
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier


@task(name="create-data", description="This task reads in and wrangles Titanic data")
def create_data():
    df = pd.read_csv("titanic.csv")
    df = df.drop(["Name"], axis=1)
    df["Sex"] = pd.factorize(df["Sex"])[0]
    y = df["Survived"]
    X = df.drop("Survived", axis=1)
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    fill_age = X_train["Age"].mean()
    X_train["Age"] = X_train["Age"].fillna(fill_age)
    X_test["Age"] = X_test["Age"].fillna(fill_age)
    return X_train, X_test, y_train, y_test


@task(name="get-models", description="Retrieve models with hyperparams", retries=2)
def get_models(n_estimators=200) -> List:
    return [
        LogisticRegression(random_state=42),
        KNeighborsClassifier(),
        DecisionTreeClassifier(),
        SVC(),
        RandomForestClassifier(n_estimators=n_estimators, max_depth=4, random_state=42),
        RandomForestClassifier(n_estimators=100, max_depth=3, random_state=42),
    ]


@task(name="train-models", description="Use models to train and predict with")
def train_model(
    model: Any, X_train: DataFrame, X_test: DataFrame, y_train: Series, y_test: Series
) -> Dict:
    clf = model.fit(X_train, y_train)
    y_pred = clf.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    return {
        "model": model.__class__.__name__,
        "params": model.get_params(),
        "accuracy": acc,
    }


@task(cache_key_fn=task_input_hash, cache_expiration=timedelta(days=1))
def get_results(results: Dict) -> Str:
    res = pd.DataFrame(results)
    return res


@flow(name="my-first-ml-flow", task_runner=DaskTaskRunner())
def my_first_ml_flow(n_estimators=200):
    with tags("dev"):
        X_train, X_test, y_train, y_test = create_data()
        models = get_models(n_estimators)
        training_runs = [
            train_model(model, X_train, X_test, y_train, y_test) for model in models
        ]
        results = get_results(training_runs)
        return results.head()


if __name__ == "__main__":
    print(my_first_ml_flow())
