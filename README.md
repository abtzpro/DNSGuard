# DNSGuard
Windows powershell based DNS defender 

## What The PS1 Script does

	•	It configures the system to use a trusted and secure DNS resolver (Cloudflare’s 1.1.1.1).
	•	It uses Cloudflare’s ‘cloudflared’ client to provide DNS over HTTPS, ensuring DNS queries are encrypted and authenticated.
	•	It configures the system to not accept DNS server configurations from DHCP, preventing rogue DHCP servers from poisoning the DNS settings.
	•	It clears the DNS cache, removing any potentially poisoned entries.
	•	It sets up firewall rules to only allow DNS queries from the ‘cloudflared’ client, blocking potential rogue DNS queries.
	•	It checks for the presence of Malwarebytes and instructs the user to install it if not found, providing protection against malware that might attempt DNS attacks.
