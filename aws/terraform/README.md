# Terraform modules for AWS deployments

## Module structure
| File Name | Purpose | Required/Optional |
|---------------|-------------|---------------|
| main.tf | core resources being deployed by this module |  required |
| variables.tf | parameters accepted by this module for configuration | required |
| versions.tf | terraform & other providers required versions | required |
| outputs.tf | relevant date that may be needed by downstream modules | optional |
| meta.tf | data sources & other ancillary code | optional |
| resource-specific.tf | depending on the size of your model, it may make sense to break out related resources into their own .tf files | optional |
| README.md | see below for recomended structure, should include a detailed overview of the module, as well as how to consume it | required |


## Module Readme Structure
```
#### Inputs:
| Variable Name | Type | Description | Required/Optional | Default Value |
|-------------|-------------|-------------|-------------|-------------|
| variable_name | type of variable | description of input | none |

#### Outputs:
| Output Name | Description |
|-------------|-------------|
| output_name | description of output |

#### Creates:
* resource a
* resource b 

#### Usage:
module "module_name" {
  source      = "path/to/module"

  variable_name1 = variable1
  variable_name2 = variable2
}
```

## Variable requirements
great things coming soon....