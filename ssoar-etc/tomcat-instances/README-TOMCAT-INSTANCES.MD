# Set as environment variable in your .profile or .bash_profile :
CATALINA_HOME="/cygdrive/c/Program\ Files/apache-tomcat-8.0.26"

# Then:
mkdir -p ~/tomcat-instances
cp -r ~/git/ssoar/ssoar-etc/tomcat-instances/ssoar-$(whoami) ~/tomcat-instances/