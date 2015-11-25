Supported tags and respective `Dockerfile` links
================================================

- [`1.11.1`, `1.11`(*1.11/Dockerfile*)](https://github.com/linagora/linshare-dockerfile/blob/1.11/Dockerfile)
- [`1.10.3`, `1.10`(*1.11/Dockerfile*)](https://github.com/linagora/linshare-dockerfile/blob/1.10/Dockerfile)
- [`1.9.5`, `1.9`(*1.11/Dockerfile*)](https://github.com/linagora/linshare-dockerfile/blob/1.9/Dockerfile)

What is Linshare?
=================

Open Source secure files sharing application, LinShare is an easy solution to make dematerialized exchanges. For businesses which want confidentiality, and traceability for their file exchanges. LinShare is a libre and free, ergonomic and intuitive software, for transferring large files.

Functionalities
---------------

</br>

* **File upload** into its own personal space,
* **File share** to internal, external, or guest persons,
* **Manage the shares** and collaborative exchange space,
* **Secure the exchanges** (authentication, time-stamping, signature, confidentiality, and anti-virus filter),


How to use this image
=====================

To be fully operational, Linshare requires several components :
* **SMTP** server
* **Database** server (Postgres & MySQL drivers included)
* **ClamAV** service (optional)

You can expose the above related settings through the following environment variables :


| Environment variable      | Default value                                                                                                |
|---------------------------|--------------------------------------------------------------------------------------------------------------|
|SMTP_HOST                  |smtp.linshare.com                                                                                             |
|SMTP_PORT                  |25                                                                                                            |
|SMTP_USER                  |                                                                                                              |
|SMTP_PASS                  |                                                                                                              |
|POSTGRES_USER              |user                                                                                                          |
|POSTGRES_PASS              |password                                                                                                      |
|POSTGRES_URL               |jdbc:postgresql://localhost:5432/linshare                                                                     |
|CLAMD_HOST                 |127.0.0.1                                                                                                     |
|CLAMD_PORT                 |3310                                                                                                          |
|JAVA_OPTS                  |                                                                                                              |

<br/>

To start using this image with the defaults settings, you can run the following commands :

```console
$ docker run -it --rm -p 8080:8080 linagora/linshare:1.11
```

And if any changes are necessary you can set the new values by passing them as follow :

```console
$ docker run -it --rm -p 8080:8080 \
-e SMTP_HOST=smtp.linshare.com \
-e SMTP_PORT=25 \
-e SMTP_USER=linshare \
-e SMTP_PASS=linshare \
-e POSTGRES_USER=linshare \
-e POSTGRES_PASS=linshare \
-e POSTGRES_URL=jdbc:postgresql://localhost:5432/linshare \
-e CLAMD_HOST=127.0.0.1 \
-e CLAMD_PORT=4410 \
-e JAVA_OPTS="-Xms1024m" \
linagora/linshare:1.11
```

In case you have more settings to tune, you have the possibility to directly expose your own configuration files :

```console
$ docker run -it --rm -p 8080:8080 \
-v data/linshare/linshare.properties:/etc/linshare/linshare.properties \
-v data/linshare/log4j.properties:/etc/linshare/log4j.properties \
-e JAVA_OPTS="-Xms1024m" \
linagora/linshare:1.11
```

License
=======

View [license information](http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3_en.pdf) for the software contained in this image.

Supported Docker versions
=========================

This image is officially supported on Docker version 1.9.0.

Support for older versions (down to 1.6) is provided on a best-effort basis.

Please see [the Docker installation documentation](https://docs.docker.com/installation/) for details on how to upgrade your Docker daemon.

User Feedback
=============

Documentation
-------------

Official Linshare documentation is available here : [Linshare Configuration Guide (pdf format)](http://download.linshare.org/documentation/admins/Linagora_DOC_LinShare-1.7.0_Guide-Config-Admin_fr_20150303.pdf).


Issues
------

If you have any problems with or questions about this image, please contact us through a [GitHub issue](https://github.com/linagora/linshare/issues).
