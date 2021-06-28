# RandBalancer

simple API loadbalancer 


#### Installation

```
git clon https://github.com/polarspetroll/randbalancer.git
cd randbalancer
chmod +x main.rb
./main.rb
```


- Configuration

``servers.json``

```json
{
	"servers" : [
		{
			"host": "127.0.0.1",    
			"port": 9090
		},
		{								//example
			"host": "10.0.0.2",
			"port": "8080"
		}
	]
}
```

- logs : ``errors.csv``