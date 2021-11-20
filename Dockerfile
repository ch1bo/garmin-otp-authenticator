# Extending kalemena/connectiq with 'make' as I use it in my workflow
FROM kalemena/connectiq:4.0.5-2021-08-09-29788b0dc
USER root
RUN apt-get update -y && apt-get install -qqy make
USER developer
