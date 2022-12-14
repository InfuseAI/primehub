#!/bin/env python
import argparse
from argparse import Namespace
from subprocess import Popen, PIPE
import json
from collections import OrderedDict

import yaml
import os


class Run(object):

    def __init__(self, command):
        self.commands = [
            Popen(command.split(' '), stdin=PIPE, stdout=PIPE, stderr=PIPE)]

    def pipe(self, command):
        proc = self.commands[-1]
        self.commands.append(
            Popen(command.split(' '), stdin=proc.stdout, stdout=PIPE, stderr=PIPE))
        return self

    def communicate(self):
        proc = self.commands[-1]
        stdout, stderr = proc.communicate()
        if stderr is not None:
            stderr = stderr.decode('utf8')
        return stdout.decode('utf8'), stderr

    def output(self):
        return self.communicate()[0]

    def json(self):
        stdout = self.communicate()[0]
        if stdout:
            return json.loads(stdout)
        return {}


def group_filter(args: Namespace, group_name):
    selector = args.copy_groups
    if selector == "*":
        return True
    selected = [x.strip() for x in selector.split(",")]
    if args.dry_run:
        print('[dry-run] selector {}, group {} from {}'.format(selector, group_name, selected))
    if group_name in selected:
        return True
    return False


def prepare_path(filename: str):
    directory = filename.split(":")[0]
    try:
        os.makedirs(directory)
    except FileExistsError:
        pass

    return filename.replace('/', "_")


def process_image(args, img, url):
    if cache_present(url):
        print("skip cached", url)
        if not args.dry_run:
            return
        else:
            print("[dry-run] continue to process image in dry-run mode => {}".format(img))

    print("process image url: ", url)
    docker_save_script = """#!/bin/bash
echo "pull image %(img)s"
docker pull %(img)s
echo "save image %(img)s"
docker save %(img)s | gzip > %(img)s.tgz
echo "%(img)s" > %(img)s.txt
gsutil cp %(img)s.txt %(txt_url)s
gsutil cp %(img)s.tgz %(url)s
    """ % dict(img=img, url=url, txt_url=url.replace(".tgz", ".txt"))

    script_path = ".{}.sh".format(prepare_path(img))
    with open(script_path, "w") as fh:
        fh.write(docker_save_script)

    if args.dry_run:
        print("[dry-run] script generated: {}".format(script_path))
        return
    ok, error = Run("bash {}".format(script_path)).communicate()
    print(ok)
    print(error)


def process_group_cache(args: Namespace, group, images):
    print("Group", group)

    cache_urls = OrderedDict()
    for _, img in images.items():
        repository, tag = img.split(':')
        if tag == "latest":
            print("skip latest tag => ", img)
            continue
        u = "{}/{}/{}.tgz".format(args.gs_cache_prefix, repository, tag)
        cache_urls[u] = img

    for url, img in cache_urls.items():
        process_image(args, img, url)


def cache_present(cache_url):
    output, error_massage = Run("gsutil stat {}".format(cache_url)).communicate()
    if error_massage and error_massage.startswith('No URLs matched:'):
        return False
    return True


def copy_tarballs(args: Namespace, cfg: dict):
    if args.gs_release_prefix is None:
        print("stop to copy tarballs -> no gs_release_prefix")
        return

    # validate prefix
    safe_gs_prefix(args.gs_release_prefix)

    do_copy = args.copy_tarballs and not args.dry_run
    for g, images in cfg.items():
        if not group_filter(args, g):
            print("skip non selected group", g)
            continue

        for img_key, img in images.items():
            repository, tag = img.split(':')
            if tag == "latest":
                print("skip latest tag => ", img)
                continue
            from_url = "{}/{}/{}.tgz".format(args.gs_cache_prefix, repository, tag)
            to_url = "{}/images/{}/{}.tgz".format(args.gs_release_prefix, g, img_key)
            copy_command = "gsutil cp {} {}".format(from_url, to_url)
            if do_copy:
                print(copy_command)
                print(Run(copy_command).communicate())
                print(copy_command.replace(".tgz", ".txt"))
                print(Run(copy_command.replace(".tgz", ".txt")).communicate())
            else:
                if args.dry_run:
                    print("[dry-run]", copy_command)
                    print("[dry-run]", copy_command.replace(".tgz", ".txt"))


def main(args: Namespace):
    verify_tools(args)
    with open(args.images_yaml, "r") as fh:
        cfg = yaml.load(fh, Loader=yaml.FullLoader)
        do_cache(args, cfg)
        copy_tarballs(args, cfg)


def do_cache(args, cfg):
    for group in cfg.keys():
        if not group_filter(args, group):
            print("skip non selected group", group)
            continue
        process_group_cache(args, group, cfg[group])


def build_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("images_yaml", help="a yaml file to configuration airgap docker-image groups")
    parser.add_argument("--dry-run", default=False, help="do all process except for put-cache", action="store_true")
    parser.add_argument("--gs-cache-prefix", help="an uri for image-cache prefix gs://uri-to-your-image-cache",
                        action="store", required=True)
    parser.add_argument("--gs-release-prefix", action="store", help="an uri for released images gs://your-releases")
    parser.add_argument("--copy-tarballs", action="store_true", default=False, help="copy tarballs to the release")
    parser.add_argument("--copy-groups", help="group names with comma or * to all groups", required=True)
    return parser


def verify_tools(args):
    gs_output = Run("gsutil ls {}".format(safe_gs_prefix(args.gs_cache_prefix))).communicate()
    if gs_output[1]:
        raise ValueError(gs_output[1])


def safe_gs_prefix(p):
    if p.endswith('/'):
        raise ValueError("gs prefix should not end with / => {}".format(p))
    return p


if __name__ == '__main__':
    main(build_arg_parser().parse_args())
