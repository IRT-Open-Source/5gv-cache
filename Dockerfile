FROM nginx:latest
RUN echo "v0.0.2"
RUN rm /etc/nginx/conf.d/default.conf
