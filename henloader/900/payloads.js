//------BIG THANKS TO SISTRO FOR THIS !!!!!--------

var LoadedMSG = "Payload Loaded!";

var getPayload = function(payload, onLoadEndCallback) {
  var req = new XMLHttpRequest();
  req.open('GET', payload);
  req.send();
  req.responseType = "arraybuffer";
  req.onload = function (event) {
      if (onLoadEndCallback) onLoadEndCallback(req, event);
  };
}

var sendPayload = function(url, data, onLoadEndCallback) {
  var req = new XMLHttpRequest();
  req.open("POST", url, true);
  req.send(data);

  req.onload = function (event) {
      if (onLoadEndCallback) onLoadEndCallback(req, event);
  };
}

//Load payloads with GoldHEN

function Loadpayloadlocal(PLfile){ //Loading Payload via Payload Param.
    var PS4IP = "127.0.0.1";

	// First do an initial check to see if the BinLoader server is running, ready or busy.
	var req = new XMLHttpRequest();
    if (PS4IP == "127.0.0.1") {
      req.open("POST", `http://${PS4IP}:9090/status`);
    } else {
      req.open("GET", `http://${PS4IP}:9090/status`);
    }
		req.send();
		req.onerror = function(){
			console.log("BinLoader Server is not running, trying online payload loading...");
            Loadpayloadonline(PLfile);
			return;
		};
		req.onload = function(){
			var responseJson = JSON.parse(req.responseText);
			if (responseJson.status=="ready"){
		    getPayload(PLfile, function (req) {
				if ((req.status === 200 || req.status === 304) && req.response) {
				    //Sending bins via IP POST Method
                    sendPayload(`http://${PS4IP}:9090`, req.response, function (req) {
                        if (req.status === 200) {
                            //alert("Payload sent !");
                        }else{
                            console.log('Payload not sent, trying online payload loading...');
                            setTimeout(() => {
                                Loadpayloadonline(PLfile);
                            }, 3000); // 3 seconds delay
                            return;
                        }
                    })
                }
			});
			} else {
				alert("Cannot Load Payload Because The BinLoader Server Is Busy");//<<If server is busy, alert message.
				return;
		  }
	  };
  }

//--------------------------------------------------

//------Payloads--------

// Load Payloads with exploit

function Loadpayloadonline(PLfile) {
    window.payload_path = PLfile;
    // If we have access to toogle_payload from lapse.js, use it
    if (typeof window.toogle_payload === 'function') {
        window.toogle_payload(PLfile);
    } else {
        console.log('Payload set for loading after exploit: ' + PLfile);
    }
}

// PSFree Fix

function load_PSFreeFix(){
    const Confirmation = confirm("Are you sure you want to load the PSFree Fix payload?");
    if (Confirmation) {
        // First try local loading through GoldHen
        Loadpayloadlocal("../payloads/ps4-psfree-fix.bin");
        
        // Also show loading message
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "PSFree Fix Payload Loaded!";
        }
    }
}

// App2USB - Transfer Apps to USB
function load_app2usb(){
    const Confirmation = confirm("Load App2USB payload? This allows transferring applications to USB storage.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/app2usb.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "App2USB Payload Loaded!";
        }
    }
}

// AppCache Install
function load_appcache_install(){
    const Confirmation = confirm("Load AppCache Install payload?");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/appcache-install.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "AppCache Install Payload Loaded!";
        }
    }
}

// Backup
function load_backup(){
    const Confirmation = confirm("Load Backup payload? This will backup your system data.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/backup.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "Backup Payload Loaded!";
        }
    }
}

// Disable Updates
function load_disable_updates(){
    const Confirmation = confirm("Load Disable Updates payload? This will block system updates.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/disable-updates.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "Disable Updates Payload Loaded!";
        }
    }
}

// Enable Updates
function load_enable_updates(){
    const Confirmation = confirm("Load Enable Updates payload? This will allow system updates.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/enable-updates.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "Enable Updates Payload Loaded!";
        }
    }
}

// FTP Server
function load_ftp(){
    const Confirmation = confirm("Load FTP Server payload? This will start an FTP server on your PS4.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/ftp.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "FTP Server Payload Loaded!";
        }
    }
}

// History Blocker
function load_history_blocker(){
    const Confirmation = confirm("Load History Blocker payload? This will block browser history tracking.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/history-blocker.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "History Blocker Payload Loaded!";
        }
    }
}

// PS4 Debug
function load_ps4debug(){
    const Confirmation = confirm("Load PS4Debug payload? This enables debugging features.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/ps4debug.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "PS4Debug Payload Loaded!";
        }
    }
}

// PUP Decrypt
function load_pup_decrypt(){
    const Confirmation = confirm("Load PUP Decrypt payload? This allows decrypting PS4 update files.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/pup-decrypt.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "PUP Decrypt Payload Loaded!";
        }
    }
}

// Restore
function load_restore(){
    const Confirmation = confirm("Load Restore payload? This will restore your system data.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/restore.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "Restore Payload Loaded!";
        }
    }
}

// RIF Renamer
function load_rif_renamer(){
    const Confirmation = confirm("Load RIF Renamer payload? This tool manages license files.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/rif-renamer.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "RIF Renamer Payload Loaded!";
        }
    }
}

// WebRTE
function load_webrte(){
    const Confirmation = confirm("Load WebRTE payload? This enables real-time editing features.");
    if (Confirmation) {
        Loadpayloadlocal("../payloads/WebRTE_900.bin");
        if (document.getElementById('log')) {
            awaitpl();
            LoadedMSG = "WebRTE Payload Loaded!";
        }
    }
}

// Make all functions globally available
window.load_PSFreeFix = load_PSFreeFix;
window.load_app2usb = load_app2usb;
window.load_appcache_install = load_appcache_install;
window.load_backup = load_backup;
window.load_disable_updates = load_disable_updates;
window.load_enable_updates = load_enable_updates;
window.load_ftp = load_ftp;
window.load_history_blocker = load_history_blocker;
window.load_ps4debug = load_ps4debug;
window.load_pup_decrypt = load_pup_decrypt;
window.load_restore = load_restore;
window.load_rif_renamer = load_rif_renamer;
window.load_webrte = load_webrte;
