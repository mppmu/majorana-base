FROM centos:7


# User and workdir settings:

USER root
WORKDIR /root


# Install yum/RPM packages:

RUN true \
    && sed -i '/tsflags=nodocs/d' /etc/yum.conf \
    && yum install -y \
        epel-release \
    && yum groupinstall -y "Development Tools" \
    && yum install -y \
        deltarpm \
        \
        wget \
        cmake \
        p7zip pbzip2 \
        nano vim \
        git git-gui gitk svn \
    && dbus-uuidgen > /etc/machine-id


# Copy provisioning script(s):

COPY provisioning/install-sw.sh /root/provisioning/


# Install CMake:

COPY provisioning/install-sw-scripts/cmake-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/cmake/bin:$PATH" \
    MANPATH="/opt/cmake/share/man:$MANPATH"

RUN provisioning/install-sw.sh cmake 3.5.1 /opt/cmake


# Install CLHep and Geant4:

COPY provisioning/install-sw-scripts/clhep-* provisioning/install-sw-scripts/geant4-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/geant4/bin:/opt/clhep/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/geant4/lib64:/opt/clhep/lib:$LD_LIBRARY_PATH" \
    G4LEDATA="/opt/geant4/share/Geant4-9.6.4/data/G4EMLOW6.32" \
    G4LEVELGAMMADATA="/opt/geant4/share/Geant4-9.6.4/data/PhotonEvaporation2.3" \
    G4NEUTRONHPDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NDL4.2" \
    G4NEUTRONXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4NEUTRONXS1.2" \
    G4PIIDATA="/opt/geant4/share/Geant4-9.6.4/data/G4PII1.3" \
    G4RADIOACTIVEDATA="/opt/geant4/share/Geant4-9.6.4/data/RadioactiveDecay3.6" \
    G4REALSURFACEDATA="/opt/geant4/share/Geant4-9.6.4/data/RealSurface1.0" \
    G4SAIDXSDATA="/opt/geant4/share/Geant4-9.6.4/data/G4SAIDDATA1.1"

RUN true \
    && yum install -y \
        expat-devel xerces-c-devel \
        libXmu-devel libXi-devel \
        libzip-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh clhep 2.1.3.1 /opt/clhep \
    && provisioning/install-sw.sh geant4 9.6.4 /opt/geant4


# Install CERN ROOT:

COPY provisioning/install-sw-scripts/root-* provisioning/install-sw-scripts/

ENV \
    PATH="/opt/root/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/root/lib:$LD_LIBRARY_PATH" \
    MANPATH="/opt/root/man:$MANPATH" \
    PYTHONPATH="/opt/root/lib:$PYTHONPATH" \
    CMAKE_PREFIX_PATH="/opt/root;$CMAKE_PREFIX_PATH" \
    JUPYTER_PATH="/opt/root/etc/notebook:$JUPYTER_PATH" \
    \
    ROOTSYS="/opt/root"

RUN true \
    && yum install -y \
        libSM-devel \
        libX11-devel libXext-devel libXft-devel libXpm-devel \
        libjpeg-devel libpng-devel \
        mesa-libGLU-devel \
    && provisioning/install-sw.sh root 6.06.08 /opt/root


# Install ORCARoot:

COPY provisioning/install-sw-scripts/orcaroot-* provisioning/install-sw-scripts/

ENV \
    LD_LIBRARY_PATH="/opt/orcaroot/lib:$LD_LIBRARY_PATH" \
    ORDIR="/opt/orcaroot"

RUN true \
    && provisioning/install-sw.sh orcaroot trunk /opt/orcaroot


# Install requirements for MAJORANA Software:

RUN true \
    && yum install -y \
        readline-devel fftw-devel \
        libcurl-devel


# Install additional packages and clean up:

RUN yum install -y \
        numactl \
        \
        http://linuxsoft.cern.ch/cern/centos/7/cern/x86_64/Packages/parallel-20150522-1.el7.cern.noarch.rpm \
    && yum clean all


# Environment variables for swmod and "/user":

ENV \
    SWMOD_HOSTSPEC="linux-centos-7-x86_64-8f24f4d9" \
    SWMOD_INST_BASE="/user/.local/sw" \
    SWMOD_MODPATH="/user/.local/sw" \
    \
    PATH="/user/.local/bin:$PATH" \
    LD_LIBRARY_PATH="/user/.local/lib:$LD_LIBRARY_PATH" \
    MANPATH="/user/.local/share/man:$MANPATH" \
    PKG_CONFIG_PATH="/user/.local/lib/pkgconfig:$PKG_CONFIG_PATH" \
    PYTHONUSERBASE="/user/.local" \
    PYTHONPATH="/user/.local/lib/python2.7/site-packages:$PYTHONPATH"


# Environment variables for MGDO (to be installed in /user):

ENV \
    MGDODIR="/user/mjsw/MGDO" \
    PATH="/user/mjsw/MGDO/install/bin:$PATH" \
    LD_LIBRARY_PATH="/user/mjsw/MGDO/install/lib:$LD_LIBRARY_PATH" \
    TAMDIR="/user/mjsw/MGDO/tam"

# Environment variables for mjd_siggen (to be installed in /user):

ENV \
    SIGGENDIR="/user/mjsw/mjd_siggen"

# Environment variables for GAT (to be installed in /user):

ENV \
    GATDIR=/user/mjsw/GAT \
    PATH="/user/mjsw/GAT/Apps:/user/mjsw/GAT/Scripts:${PATH}" \
    LD_LIBRARY_PATH="/user/mjsw/GAT/lib:${LD_LIBRARY_PATH}"


# Environment variables for MJOR (to be installed in /user):

ENV \
    MJORDIR=/user/mjsw/MJOR \
    LD_LIBRARY_PATH="/user/mjsw/MJOR/lib:${LD_LIBRARY_PATH}" \
    PATH="/user/mjsw/MJOR/Apps:/user/mjsw/MJOR/Scripts:${PATH}"


# Copy MAJORANA software install scripts:

COPY scripts/mj-sw-*.sh /usr/local/bin/


# Final steps

CMD /bin/bash