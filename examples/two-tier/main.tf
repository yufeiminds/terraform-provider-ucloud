# Specify the provider and access details
provider "ucloud" {
  region = "${var.region}"
}

data "ucloud_zones" "default" {}

data "ucloud_images" "default" {
  availability_zone = "${data.ucloud_zones.default.zones.0.id}"
  name_regex        = "^CentOS 7.[1-2] 64"
  image_type        = "base"
}

resource "ucloud_lb" "default" {
  name = "tf-example-two_tier"
  tag  = "tf-example"
}

resource "ucloud_lb_listener" "default" {
  load_balancer_id = "${ucloud_lb.default.id}"
  protocol         = "https"
}

resource "ucloud_lb_attachment" "default" {
  load_balancer_id = "${ucloud_lb.default.id}"
  listener_id      = "${ucloud_lb_listener.default.id}"
  resource_id      = "${element(ucloud_instance.web.*.id, count.index)}"
  port             = 80
  count            = "${var.count}"
}

resource "ucloud_lb_rule" "default" {
  load_balancer_id = "${ucloud_lb.default.id}"
  listener_id      = "${ucloud_lb_listener.default.id}"
  backend_ids      = ["${ucloud_lb_attachment.default.*.id}"]
  domain           = "www.ucloud.cn"
}

resource "ucloud_instance" "web" {
  name              = "tf-example-two_tier-${format(var.count_format, count.index+1)}"
  tag               = "tf-example"
  availability_zone = "${data.ucloud_zones.default.zones.0.id}"
  instance_type     = "n-standard-1"

  # use cloud disk as data disk
  data_disk_size = 50
  image_id       = "${data.ucloud_images.default.images.0.id}"
  root_password  = "${var.instance_password}"

  count = "${var.count}"
}
