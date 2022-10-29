#!/usr/bin/python3
"""A module for Fabric script that generates a .tgz archive."""
import os
from datetime import datetime
from fabric.api import local, runs_once, env, put, run


env.hosts = ['34.232.80.156', '100.26.49.12']
'''server Ips'''


@runs_once
def do_pack():
    """Archives the static files."""
    if not os.path.isdir("versions"):
        os.mkdir("versions")
    d_time = datetime.now()
    output = "versions/web_static_{}{}{}{}{}{}.tgz".format(
        d_time.year,
        d_time.month,
        d_time.day,
        d_time.hour,
        d_time.minute,
        d_time.second
    )
    try:
        print("Packing web_static to {}".format(output))
        local("tar -cvzf {} web_static".format(output))
        size = os.stat(output).st_size
        print("web_static packed: {} -> {} Bytes".format(output, size))
    except Exception:
        output = None
    return output


def do_deploy(archive_path):
    """Deploys the static files to the host servers.
    Args:
        archive_path (str): The path to the archived static files.
    """
    if not os.path.exists(archive_path):
        return False
    file_name = os.path.basename(archive_path)
    folder = file_name.replace(".tgz", "")
    path = "/data/web_static/releases/{}/".format(folder)
    success = False
    try:
        put(archive_path, "/tmp/{}".format(file_name))
        run("mkdir -p {}".format(path))
        run("tar -xzf /tmp/{} -C {}".format(file_name, path))
        run("rm -rf /tmp/{}".format(file_name))
        run("mv {}web_static/* {}".format(path, path))
        run("rm -rf {}web_static".format(path))
        run("rm -rf /data/web_static/current")
        run("ln -s {} /data/web_static/current".format(path))
        print('New version deployed!')
        success = True
    except Exception:
        success = False
    return success


def deploy():
    """Archives and deploys the static files to the host servers.
    """
    archive_path = do_pack()
    return do_deploy(archive_path) if archive_path else False
