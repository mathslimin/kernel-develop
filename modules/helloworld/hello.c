/* Defining __KERNEL__ and MODULE allows us to access kernel-level code not
 * usually available to userspace programs.*/
#undef __KERNEL__
#define __KERNEL__
#undef MODULE
#define MODULE

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

static int __init hello_init(void) {
  printk(KERN_INFO "Hello world!\n");
  return 0; // Non-zero return means that the module couldn't be loaded.
}

static void __exit hello_exit(void) { printk(KERN_INFO "Exit  module.\n"); }

module_init(hello_init);
module_exit(hello_exit);

MODULE_AUTHOR("utopiaor <hongchunbo@hotmail.com>");
MODULE_LICENSE("GPL v2");
