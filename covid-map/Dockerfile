FROM rcepka/shiny-verse:4.2.3


RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    dpkg \
    cron \
    nano

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean




# Create the log file to be able to run tail
#RUN touch /var/log/cron.log
#RUN chmod 0644 /var/log/cron.log




#COPY /app-chart /srv/shiny-server/app-chart
COPY /app ./srv/shiny-server/app
#COPY /app-map ./app-map



# shiny-server runs at 3838
#COPY /app-chart/shiny-server.conf /etc/shiny-server/shiny-server.conf
# Shiny server runs at 3839
#COPY /app-map/shiny-server.conf /etc/shiny-server/shiny-server.conf




# install renv & restore packages
#RUN Rscript /srv/shiny-server/app-chart/inc/install_packages.R


#CMD service cron start
#CMD service cron restart
#RUN service cron start
#RUN service cron restart



# Setup cron job
#RUN (crontab -l ; echo "* * * * * echo "Hello cron world" >> /var/log/cron.log") | crontab
#RUN (crontab -l ; echo "*/2 * * * * Rscript /app-chart/inc/get_data.R  >> /var/log/cron.log") | crontab



# Run the command on container startup
#CMD cron && tail -f /var/log/cron.log




# expose port
EXPOSE 3838
#EXPOSE 3839


# run app on container start
#CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app-chart', host = '0.0.0.0', port = 3838)"]
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/app', host = '0.0.0.0', port = 3838)"]
#CMD ["R", "-e", "shiny::runApp('/app-map', host = '0.0.0.0', port = 3838)"]
