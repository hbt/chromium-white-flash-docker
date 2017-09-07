FROM ubuntu:14.04
RUN apt-get update -q 

RUN apt-get install -qy \
  build-essential \
  curl \
  less \
  git \
  sudo \
  python 

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

RUN rm .gclient &> /dev/null
RUN rm .gclient_entries &> /dev/null

# download chromium source code  (needed for rebase and such)
RUN git config --global user.email "hassenbentanfous@gmail.com"
RUN git config --global user.name "hbt"

RUN fetch --nohooks chromium

# checkout specific version 
RUN cd src && git fetch && git checkout tags/59.0.3071.109 && git checkout -b v/59.0.3071.109

# build ubuntu deps
RUN sudo src/build/install-build-deps.sh --no-prompt 

# reset sub repositories and sync
RUN gclient sync --with_branch_heads --with_tags -Rv 

RUN cd src && gn gen out/Release --args="is_component_build=true is_debug = false symbol_level = 0 enable_nacl = true remove_webcore_debug_symbols = true enable_linux_installer = true"

# Build Chromium. (this takes time. add highcpus vms)
WORKDIR src
#RUN ninja -C out/Release chrome -j18
#RUN ninja -C out/Release chrome 

# create deb package
ENV IGNORE_DEPS_CHANGES 1
RUN ninja -C out/Release  "chrome/installer/linux:beta_deb"

# view instructions for installing deb package here https://github.com/hbtlabs/chromium-white-flash-fix

