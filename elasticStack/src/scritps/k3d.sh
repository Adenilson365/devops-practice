#!/

k3d cluster create -a 3 \
-p 80:30000 -p 443:30001 \
--k3s-node-label "nodeType=hot@agent:0" \
--k3s-node-label "nodeType=hot@agent:1" \
--k3s-node-label "nodeType=warm@agent:2"