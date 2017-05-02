uglifyjs = uglifyjs

all: build

compress: lib/generated/compressed.js lib/generated/data-compressed.js

# The order of these .js input files matters
lib/generated/compressed.js: lib/jquery.js lib/jquery-ui.js lib/angular.js lib/bootstrap/js/bootstrap.js lib/sortable.js lib/slider.js lib/ui-bootstrap.js lib/moment.js lib/moment-timezone.js lib/typeahead.js
	$(uglifyjs) $^ -c -o $@

lib/generated/data-compressed.js: lib/generated/data.js
	$(uglifyjs) $^ -c -o $@

download-timezone-info: data/timezones.json data/raw/windows_zones.xml data/raw/supplemental_data.xml data/raw/countryInfo.txt data/raw/cities15000.txt

data/timezones.json:
	wget -c https://raw.githubusercontent.com/moment/moment-timezone/develop/data/packed/latest.json -O $@

data/raw/windows_zones.xml:
	wget -c http://unicode.org/repos/cldr/trunk/common/supplemental/windowsZones.xml -O $@

data/raw/supplemental_data.xml:
	wget -c http://unicode.org/repos/cldr/trunk/common/supplemental/supplementalData.xml -O $@

data/raw/countryInfo.txt:
	wget -c http://download.geonames.org/export/dump/countryInfo.txt -O $@

data/raw/cities15000.zip:
	wget -c http://download.geonames.org/export/dump/cities15000.zip -O $@

data/raw/cities15000.txt: data/raw/cities15000.zip
	unzip -d $(@D) $<

lib/generated/data.js: data/convert.py
	mkdir -p $(@D)
	python data/convert.py

data/convert.py: data/timezones.json data/raw/countryInfo.txt data/raw/cities15000.txt

build: compress timesched.html
	mkdir -p _deploy
	cp timesched.html _deploy/index.html
	cp -R lib _deploy/
	cp -R static _deploy/static/

deploy: build
	rsync -a _deploy/ flow.srv.pocoo.org:/srv/websites/timesched.pocoo.org/static
	rm -rf _deploy

clean:
	rm -rf _deploy

.PHONY: build compress download-timezone-info upload
