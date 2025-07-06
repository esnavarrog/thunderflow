$( document ).on('turbolinks:load', common_events)

function common_events() {
    var XLSX = require("xlsx/xlsx.js");
    const moment = require('moment/moment.js');

    function readofXlsxOld(file, url, branch_id) {
        var reader = new FileReader();

        reader.onload = function (e) {
            var data = e.target.result;
            var workbook = XLSX.read(data, { type: 'binary' });
            workbook.SheetNames.forEach(function (sheetName) {
                var XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], { header: 1 });
                var params = [];
                for (let i = 0; i < XL_row_object.length; i++) {
                    let element = XL_row_object[i];
                    let data;
                    let date_start = formatExcelDate(element[0]);
                    let date_end = formatExcelDate(element[17]);
                    let validate = isValidRow(element);

                    if (!isNaN(element[13])) {
                        if (validate) {
                            data = {
                                date_start: date_start,
                                branch_id: branch_id,
                                contact_name: element[1],
                                contact_lastname: element[2],
                                rut: element[3],
                                email: element[4],
                                phone_number: element[5],
                                address_street: element[6],
                                address_number: element[7] !== undefined ? element[7].toString() : '',
                                dpto: element[8],
                                region: element[9],
                                commune: element[10].toLowerCase(),
                                city: element[11],
                                type_deliver: element[12],
                                description: element[23],
                                height: element[13],
                                width: element[14],
                                depth: element[15],
                                weight: element[16],
                                date_end: date_end,
                                time_deliver_open: formatExcelTime(element[18]),
                                time_deliver_close: formatExcelTime(element[19]),
                                time_open: formatExcelTime(element[20]),
                                time_close: formatExcelTime(element[21]),
                                reference: element[22]
                            };
                            params.push(data);
                        }
                    } else {
                        handleErrors(element, params);
                    }
                }
                handleParams(params, url, branch_id);
            });
        };
        reader.onerror = function (ex) {
            console.log(ex);
        };

        reader.readAsBinaryString(file);
    }

    function deliveriesForDeal(file, url) {
        var reader = new FileReader();

        reader.onload = function (e) {
            var data = e.target.result;
            var workbook = XLSX.read(data, { type: 'binary' });
            workbook.SheetNames.forEach(function (sheetName) {
                var XL_row_object = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], { header: 1 });
                var params = [];
                for (let i = 0; i < XL_row_object.length; i++) {
                    let element = XL_row_object[i];
                    if (!isNaN(element[0])) {
                        let data = {
                            id: element[0],
                            price: element[11],
                            price_deliver: element[10]
                        };
                        params.push(data);
                    }
                }
                $.ajax({
                    dataType: 'script',
                    method: 'PUT',
                    url: url,
                    data: { delivery: params }
                });
            });
        };
        reader.onerror = function (ex) {
            console.log(ex);
        };

        reader.readAsBinaryString(file);
    }

    $('body').on('change', '#upload-excel', function (e) {
        e.preventDefault();
        let files = this.files;
        let url = $(this).data('url');
        let branch_id = $(this).data('branch');
        $('.loader').fadeIn('slow');
        for (let index = 0; index < files.length; index++) {
            const file = files[index];
            var name = getFileExtension(file.name);
            if (name == "xlsx" || name === "xls") {
                if (branch_id) {
                    $('#upload-excel-submit').click();
                } else {
                    deliveriesForDeal(file, url);
                }
            } else {
                swal({ text: "El archivo no es un archivo de lectura válido.", icon: 'warning', button: "Aceptar" });
            }
        }
        $(this).val('');
    });

    function getFileExtension(filename) {
        return filename.slice((filename.lastIndexOf(".") - 1 >>> 0) + 2);
    }

    function ExcelDateToJSDate(serial) {
        var utc_days = Math.floor(serial - 25569);
        var date_info = new Date(utc_days * 86400 * 1000);
        var fractional_day = serial - Math.floor(serial);
        var total_seconds = Math.floor(86400 * fractional_day);
        var seconds = total_seconds % 60;
        total_seconds -= seconds;
        var hours = Math.floor(total_seconds / (60 * 60));
        var minutes = Math.floor(total_seconds / 60) % 60;
        return new Date(Date.UTC(date_info.getFullYear(), date_info.getMonth(), date_info.getDate(), hours, minutes, seconds));
    }

    function formatExcelDate(serial) {
        let date = moment(ExcelDateToJSDate(serial)).format('DD-MM-YYYY');
        return date === "Invalid date" ? '' : date;
    }

    function formatExcelTime(serial) {
        // Ajuste para manejar correctamente las fracciones de día
        let time = moment(ExcelDateToJSDate(serial)).format('HH:mm');
        return time === "Invalid date" ? '' : time;
    }

    function isValidRow(element) {
        return moment(ExcelDateToJSDate(element[0])).format('DD-MM-YYYY') !== "Invalid date" ||
            element[0] !== undefined || element[1] !== undefined || element[5] !== undefined ||
            element[6] !== undefined || element[10] !== undefined || element[13] !== undefined ||
            element[14] !== undefined || element[15] !== undefined || element[16] !== undefined;
    }

    function handleErrors(element, params) {
        let error = 'error';
        let date = 'date';
        if (!isNaN(element[7])) {
            if (moment(ExcelDateToJSDate(element[0])).format('DD-MM-YYYY') === "Invalid date") {
                params.push(date);
            }
            params.push(error);
        }
    }

    function handleParams(params, url, branch_id) {
        let title = 'Faltan datos!';
        let message = "El archivo contiene algún error o falta información importante. Revisa que todas las casillas amarillas sean rellenadas en el excel y vuelve a intentar.";
        if (params.includes('error') || params.includes('date')) {
            if (params.includes('date')) {
                title = "Error en las fechas";
                message = "Hay un error en alguna fecha, el formato debe ser ejemplo: 12-09-2022 o 12/09/2022, corrige y vuelve a subir el archivo.";
            }
            swal({ title: title, text: message, icon: 'warning', dangerMode: true, button: "Aceptar" });
        } else {
            $.ajax({
                dataType: 'script',
                method: 'POST',
                url: url,
                data: { delivery: params, branch_id: branch_id }
            });
        }
    }
}