%if %{_package_edition} == "full"
Requires: curl, libx11_6, xdg-utils, fonts-ttf-dejavu, fonts-ttf-liberation
%else
Requires: curl, libx11_6, libxscrnsaver1, libgtkglext1.0_0, libcairo2, xdg-utils, fonts-ttf-dejavu, fonts-ttf-liberation
%endif
#Suggests: webcore-fonts
