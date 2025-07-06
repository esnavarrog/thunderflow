// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference

// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
global.$ = require("jquery");

Rails.start()
Turbolinks.start()
ActiveStorage.start()
// import 'jquery/dist/jquery';
import 'bootstrap/dist/js/bootstrap';
// import '../js/bootstrap_js_files.js';
import "xlsx/xlsx.js";
import "moment/moment.js";
require("@nathanvda/cocoon");
require("flatpickr");
require("flatpickr/dist/l10n/es.js").default.es;
require('packs/base');
require('packs/tracking');
require('packs/widgets/xlsx');
require('packs/widgets/resize');
require('packs/deal');
require("packs/mask");
require("packs/maps");
require("packs/profile");
require("packs/resource");
require("packs/deliveries");
require("packs/withdrawal_receipt");
require('packs/widgets/statuschange');
require('packs/setting')
require('packs/default_price');
import "select2";
import "chartkick/chart.js";