#! /usr/bin/env python3

import subprocess
from pathlib import Path
from . import _plac as plac


PROJECT_ROOT = Path(__file__).parent.parent
DOCKER_DIR = PROJECT_ROOT / "docker"


@plac.pos('branch', "Repository branch or current for using /src (default)")
@plac.opt('tag', "Docker image tag (default: None)")
@plac.opt('port', "Port for QPanel (default: 8080)")
@plac.opt('extras', "Extras for docker build")
@plac.flg('development', "Development mode")
def docker_build(branch: str = "current", tag: str = None, port: int = 8080, extras: str = None, development: bool = False):
    """Build docker image"""
    environment = "dev" if development else "prod"
    mode = "current" if branch == "current" else "repo"
    dockerfile = DOCKER_DIR / Path(environment) / Path(f"Dockerfile.{mode}")

    port_bd_args = ["--build-arg", f"QPANEL_PORT={port}"]
    extras_bd_args = ["--build-arg", f"EXTRAS={extras}"] if extras else []
    branch_bd_args = ["--build-arg", f"GIT_BRANCH={branch}"] if mode == "repo" else []
    build_args = [*port_bd_args, *extras_bd_args, *branch_bd_args]

    tag_args = ["--tag", tag] if tag else []

    cmd = ["docker", "build", *tag_args, *build_args, "-f", str(dockerfile), "."]
    print(f'Building docker image: {dockerfile}')
    print(f'> ', ' '.join(cmd))
    subprocess.run(cmd, check=True, cwd=PROJECT_ROOT)


if __name__ == "__main__":
    plac.call(docker_build)
