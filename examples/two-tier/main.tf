# Specify the provider and access details
provider "ucloud" {
  region = "cn-bj2"
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
  availability_zone = "cn-bj2-05"
  instance_type     = "n-highcpu-1"

  # use cloud disk as data disk
  image_id       = "uimage-kg0w4u"
  root_password  = "${var.instance_password}"

  count = "${var.count}"
}
