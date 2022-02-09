variable "tf" {
  description = "Terraformアプリケーション情報"
  type = object({
    name          = string
    shortname     = string
    env           = string
    fullname      = string
    fullshortname = string
  })
}

variable "in_development" {
  description = "ログ保管用S3バケットにオブジェクトが残っていてもバケットごと強制削除されます"
  type        = bool
  default     = false
}
