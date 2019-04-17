
if [[ ! "$(kubectl config current-context)" == "kubernetes-admin@primehub" ]]; then
  echo "should work kindly"
  exit 1
fi

export DOMAIN=10.88.88.88.xip.io:8080
