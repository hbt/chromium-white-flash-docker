FROM ubuntu:14.04
RUN apt-get update -q 

RUN apt-get install -qy \
  build-essential \
  curl \
  less \
  git \
  sudo 

# Add a user that can `sudo`.
RUN useradd --create-home --shell /bin/bash user \
 && echo "user ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/use

# Don't be root.
USER user
ENV HOME /home/user
WORKDIR /home/user


# Install Chromium's depot_tools.
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH $PATH:/home/user/depot_tools
RUN echo "\n# Add Chromium's depot_tools to the PATH." >> .bashrc \
 && echo "export PATH=\"\$PATH:/home/user/depot_tools\"" >> .bashrc

# Disable gyp_chromium for faster updates.
ENV GYP_CHROMIUM_NO_ACTION 1
RUN echo "\n# Disable gyp_chromium for faster updates." >> .bashrc \
 && echo "export GYP_CHROMIUM_NO_ACTION=1" >> .bashrc

# Disable Chromium's SUID sandbox, because it's not needed anymore.
# Source: https://chromium.googlesource.com/chromium/src/+/master/docs/linux_suid_sandbox_development.md
ENV CHROME_DEVEL_SANDBOX ""
RUN echo "\n# Disable Chromium's SUID sandbox." >> .bashrc \
 && echo "export CHROME_DEVEL_SANDBOX=\"\"" >> .bashrc


# Create the Chromium directory.
RUN mkdir /home/user/chromium
WORKDIR chromium

COPY .gclient . 
COPY .gclient_entries . 

