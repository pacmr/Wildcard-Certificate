# Wildcard-Certificate
Create your own self signed Wildcard Certificate with root CA for Android, Iphone, Windows and Linux.

Run the bash script on a Linux machine and it generates the following files:
- root_CA.key  
The root_CA.key file is your CA root private key. 
Keep this one save and the password to create it. 
 
- root_CA_der.crt  
The root_CA_der.crt file is your CA root certificate. 
It is valid for 20 years, so generated ones. :-).
Import this certificaat on Android, Iphone, Windows and Linux. 
  
- server.key and server.crt   
These are to be generated every year.  
Copy them to your ssl dir in your webserver.  
This certificate is an wildcard certificate: *.domain.my  

- server.pfx
This is an combination of server.key and server.crt
Some applications need this, ie jellyfin
This is to be generated every year.
This certificate is an wildcard certificate: *.domain.my 

Inside the script are comments what it does.

Enjoy
