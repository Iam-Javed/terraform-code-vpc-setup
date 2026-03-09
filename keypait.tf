resource "aws_key_pair" "my-key" {
    key_name = "my-key"
    public_key = file("~/Downloads/terraform/complete_infra_setup/my-key.pub")
}