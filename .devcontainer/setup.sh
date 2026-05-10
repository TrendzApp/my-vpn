bash
#!/bin/bash
set -e

echo "🔧 Installing WireGuard..."
sudo apt update
sudo apt install -y wireguard-tools curl qrencode

echo "🔑 Generating WireGuard keys..."
wg genkey | tee privatekey | wg pubkey > publickey

PRIVATE_KEY=$(cat privatekey)
PUBLIC_KEY=$(cat publickey)

echo "📝 Creating WireGuard config..."
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = CLIENT_PUBLIC_KEY_HERE
AllowedIPs = 10.0.0.2/32
EOF

echo "🌐 Enabling IP forwarding..."
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo ""
echo "✅ WireGuard installed successfully!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 SERVER PUBLIC KEY (copy this):"
echo "$PUBLIC_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  NEXT STEPS:"
echo "1. On your PC, generate client keys"
echo "2. Replace CLIENT_PUBLIC_KEY_HERE in /etc/wireguard/wg0.conf"
echo "3. Run: sudo wg-quick up wg0"
echo ""
