eksctl create iamserviceaccount `
  --cluster devops-eks `
  --namespace kube-system `
  --name external-dns `
  --attach-policy-arn arn:aws:iam::523835808362:policy/ExternalDNSPolicy `
  --approve `
  --override-existing-serviceaccounts `
  --region ap-south-1

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns

helm repo update

helm install external-dns external-dns/external-dns `
  --namespace kube-system `
  --set provider=aws `
  --set policy=sync `
  --set aws.zoneType=public `
  --set serviceAccount.create=false `
  --set serviceAccount.name=external-dns `
  --set domainFilters[0]=mydevop.net