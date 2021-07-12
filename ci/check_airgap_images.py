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


def check_notebook_images(all_images, bootstrap_crds):
    section("crds.yaml")
    image_crds = load(bootstrap_crds)
    notebook_images = re.findall(r'url(ForGpu)*: *(.+)', image_crds)
    notebook_images = [x[1] for x in notebook_images]
    for img in notebook_images:
        found = img in all_images
        print("check notebook image: {} => {}".format(img, found))
        exit_when_not_found(found, img)


def check_ph_template_images(all_images, phapptemplates_dirs):
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


def exit_when_not_found(found, image):
    if not found:
        print("Cannot find the image [{}] in the images.yaml".format(image))
        sys.exit(1)


def check_version_locked(all_images):
    section("Version locked checking")
    git_tag = os.environ.get('CIRCLE_TAG', None)
    images_with_latest_tag = [x.strip() for x in all_images.split('\n') if ':latest' in x]

    if not git_tag:
        print("skip checking version locked, when the job is called without CIRCLE_TAG")
        if images_with_latest_tag:
            print("[warning] images without version locked")
            for img in images_with_latest_tag:
                print(img)
    else:
        print('TAG: {}'.format(git_tag))
        if images_with_latest_tag:
            print("[error] found images without version locked")
            for img in images_with_latest_tag:
                print(img)

            print("")
            sys.exit(1)


def main(airgap_image_list, bootstrap_crds, phapptemplates_dirs):
    all_images = load(airgap_image_list)
    check_version_locked(all_images)
    check_notebook_images(all_images, bootstrap_crds)
    check_ph_template_images(all_images, phapptemplates_dirs)


if __name__ == '__main__':
    images, bootstrap_crds, phapptemplates_dir = sys.argv[1:]
    section("Inputs")
    print("images.yaml => {}".format(images))
    print("crds.yaml => {}".format(bootstrap_crds))
    print("ph-app-templates => {}".format(phapptemplates_dir))

    main(images, bootstrap_crds, phapptemplates_dir)
    print("\nEverything is OK.")
    sys.exit(0)
