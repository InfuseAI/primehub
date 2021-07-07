import sys
import re


def load(f):
    with open(f, "r") as fh:
        return fh.read()


def main(airgap_image_list, bootstrap_crds):
    all_images = load(airgap_image_list)
    image_crds = load(bootstrap_crds)

    notebook_images = re.findall(r'url(ForGpu)*: *(.+)', image_crds)
    notebook_images = [x[1] for x in notebook_images]
    for img in notebook_images:
        found = img in all_images
        print("check notebook image: {} => {}".format(img, found))
        if not found:
            sys.exit(1)


if __name__ == '__main__':
    images, bootstrap_crds = sys.argv[1:]
    main(images, bootstrap_crds)
    sys.exit(0)
