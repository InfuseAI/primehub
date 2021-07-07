import sys
import re
import os


def section(title):
    print("\n{}".format("=" * 24))
    print("{}".format(title))
    print("{}".format("=" * 24))


def load(f):
    with open(f, "r") as fh:
        return fh.read()


def main(airgap_image_list, bootstrap_crds, phapptemplates_dirs):
    all_images = load(airgap_image_list)
    check_notebook_images(all_images, bootstrap_crds)

    section("ph-app-templates")
    phapps = os.path.abspath(phapptemplates_dirs)
    for root, dirs, files in os.walk(phapps):
        for tpl in files:
            p = load(os.path.join(root, tpl))
            phapp_images = re.findall(r'image: +([^ \n]+)', p)
            for img in phapp_images:
                found = img in all_images
                print("check ph-app image: {} => {}".format(img, found))
                exit_when_not_found(found, img)

        pass


def exit_when_not_found(found, image):
    if not found:
        print("Cannot find the image [{}] in the images.yaml".format(image))
        sys.exit(1)


def check_notebook_images(all_images, bootstrap_crds):
    section("crds.yaml")
    image_crds = load(bootstrap_crds)
    notebook_images = re.findall(r'url(ForGpu)*: *(.+)', image_crds)
    notebook_images = [x[1] for x in notebook_images]
    for img in notebook_images:
        found = img in all_images
        print("check notebook image: {} => {}".format(img, found))
        exit_when_not_found(found, img)


if __name__ == '__main__':
    images, bootstrap_crds, phapptemplates_dir = sys.argv[1:]
    section("Inputs")
    print("images.yaml => {}".format(images))
    print("crds.yaml => {}".format(bootstrap_crds))
    print("ph-app-templates => {}".format(phapptemplates_dir))

    main(images, bootstrap_crds, phapptemplates_dir)
    print("\nEverything is OK.")
    sys.exit(0)
