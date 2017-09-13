FROM ubuntu:14.04
RUN apt-get update -q 

RUN apt-get install -qy \
  build-essential \
  curl \
  less \
  git \
  sudo \
  vim \
  less \
  wget \
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

#RUN rm .gclient &> /dev/null
#RUN rm .gclient_entries &> /dev/null

ADD compile.sh /home/user/chromium
ADD select-branch-install-deps.sh /home/user/chromium


# download chromium source code  (needed git auth for rebase and such)
RUN git config --global user.email "hassenbentanfous@gmail.com"
RUN git config --global user.name "hbt"

RUN fetch --nohooks chromium

# checkout specific version 
RUN cd src && git fetch && git checkout tags/57.0.2925.0 && git checkout -b v/57.0.2925.0

# build ubuntu deps
RUN sudo src/build/install-build-deps.sh --no-prompt 

# reset sub repositories and sync
RUN gclient sync --with_branch_heads --with_tags -Rv --disable-syntax-validation

RUN cd src && gn gen out/Release --args='is_debug = false symbol_level = 0 enable_nacl = true remove_webcore_debug_symbols = true enable_linux_installer = true enable_ac3_eac3_audio_demuxing = true enable_google_now = false enable_hevc_demuxing = true enable_hotwording = false enable_iterator_debugging = false enable_mse_mpeg2ts_stream_parser = true enable_nacl = true exclude_unwind_tables = true ffmpeg_branding = "Chrome" is_component_build = false proprietary_codecs = true remove_webcore_debug_symbols = true symbol_level = 0 target_cpu = "x64" enable_hangout_services_extension = true rtc_use_h264 = true rtc_use_lto = true use_openh264 = true chrome_pgo_phase = 0 full_wpo_on_official = false is_official_build = false'


# Build Chromium. (this takes time. add highcpus vms. 18cpus does the trick)
WORKDIR src
#RUN ninja -C out/Release chrome -j18
RUN ninja -C out/Release chrome 

# create deb package
ENV IGNORE_DEPS_CHANGES 1
RUN ninja -C out/Release  "chrome/installer/linux:beta_deb"


