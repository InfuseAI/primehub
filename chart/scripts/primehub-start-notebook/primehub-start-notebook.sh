# reference
# https://github.com/jupyter/docker-stacks/blob/ca3d8b74aa54e780510bcfa608d29cb43294dfba/base-notebook/Dockerfile#L126-L130

# scripts would be mounted at /opt/primehub-start-notebook/
cp -n /opt/primehub-start-notebook/start* /usr/local/bin/ || true
mkdir -p /etc/jupyter || true
cp -n /opt/primehub-start-notebook/jupyter_notebook_config.py /etc/jupyter/ || true

#
export

# launch process
cd /home/jovyan
chown -R jovyan:jovyan /home/jovyan/.local
NB_USER="jovyan" NB_UID="$(id jovyan -u)" NB_GID="$(id jovyan -g)" start-singleuser.sh --ip=0.0.0.0 --port=8888
