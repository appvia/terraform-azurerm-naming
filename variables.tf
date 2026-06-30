variable "prefix" {
  type        = list(string)
  default     = []
  description = "List of prefix components prepended to resource names."
}

variable "suffix" {
  type        = list(string)
  default     = []
  description = "List of suffix components appended to resource names."
}

variable "prefix_short" {
  type        = list(string)
  default     = null
  description = "Short alternatives for prefix elements, used when the full name exceeds a resource's max length. Must be the same length as prefix if provided."

  validation {
    condition     = var.prefix_short == null || length(var.prefix_short) == length(var.prefix)
    error_message = "prefix_short must have the same number of elements as prefix."
  }
}

variable "suffix_short" {
  type        = list(string)
  default     = null
  description = "Short alternatives for suffix elements, used when the full name exceeds a resource's max length. Must be the same length as suffix if provided."

  validation {
    condition     = var.suffix_short == null || length(var.suffix_short) == length(var.suffix)
    error_message = "suffix_short must have the same number of elements as suffix."
  }
}

variable "unique_seed" {
  type        = string
  default     = ""
  description = "Custom seed for unique string generation. If empty, a random value is used."
}

variable "unique_length" {
  type        = number
  default     = 4
  description = "Length of the unique suffix appended to name_unique variants."

  validation {
    condition     = var.unique_length >= 1 && var.unique_length <= 16
    error_message = "unique_length must be between 1 and 16."
  }
}

variable "unique_include_numbers" {
  type        = bool
  default     = true
  description = "Whether to include numbers in the unique suffix."
}

variable "slug_overrides" {
  type        = map(string)
  default     = {}
  description = "Override default slugs for specific resource types. Keys must match resource definition keys. Example: { container_registry = \"acr\" }"
}
