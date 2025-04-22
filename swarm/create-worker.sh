export WORKER1_ID=$(curl -X POST "$DROPLETS_API"\
       -d'{
       "name":"minitwit.worker1",
       "tags":["prod"],
       "region":"fra1",
       "size":"s-1vcpu-1gb",
       "image":"docker-20-04",
       "ssh_keys": [
	"64:14:b5:67:6a:30:a5:3f:f9:7d:9b:ee:30:37:cf:36",
	"4b:f6:bc:0d:0c:3f:d7:a8:58:ef:08:89:13:da:56:4c",
	"56:4e:42:f7:78:85:83:12:d2:10:ff:aa:95:8e:11:a9",
	"8a:27:50:e5:1c:79:14:24:95:96:0d:6b:c9:8d:21:09",
	"ad:b5:20:84:4f:93:6f:66:b2:71:09:66:7c:18:a7:0b",
	"da:90:30:e5:52:fb:77:1d:94:15:54:df:c1:3e:9a:57",
	"d6:c8:50:47:38:b1:a7:75:45:4e:e7:8c:41:81:fb:93"]}'\
       -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
       | jq -r .droplet.id )\
       && sleep 3 && echo $WORKER1_ID

export WORKER2_ID=$(curl -X POST "$DROPLETS_API"\
       -d'{
       "name":"minitwit.worker2",
       "tags":["prod"],
       "region":"fra1",
       "size":"s-1vcpu-1gb",
       "image":"docker-20-04",
       "ssh_keys": [
	"64:14:b5:67:6a:30:a5:3f:f9:7d:9b:ee:30:37:cf:36",
	"4b:f6:bc:0d:0c:3f:d7:a8:58:ef:08:89:13:da:56:4c",
	"56:4e:42:f7:78:85:83:12:d2:10:ff:aa:95:8e:11:a9",
	"8a:27:50:e5:1c:79:14:24:95:96:0d:6b:c9:8d:21:09",
	"ad:b5:20:84:4f:93:6f:66:b2:71:09:66:7c:18:a7:0b",
	"da:90:30:e5:52:fb:77:1d:94:15:54:df:c1:3e:9a:57",
	"d6:c8:50:47:38:b1:a7:75:45:4e:e7:8c:41:81:fb:93"]}'\
       -H "$BEARER_AUTH_TOKEN" -H "$JSON_CONTENT"\
       | jq -r .droplet.id )\
       && sleep 3 && echo $WORKER2_ID