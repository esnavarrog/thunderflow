

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
global.$ = require("jquery");
// import '../js/bootstrap_js_files.js';


Rails.start()
Turbolinks.start()
ActiveStorage.start()


require("packs/landpage/main");


