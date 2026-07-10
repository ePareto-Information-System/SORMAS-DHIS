<%@page import="java.sql.ResultSet"%>
<%@page import="com.mirabilia.org.hzi.Util.dhis.optionFiler"%>
<%@page import="java.util.logging.Logger"%>
<%@page import="java.util.logging.Level"%>
<%@page import="java.sql.SQLException"%>
<%@page import="com.mirabilia.org.hzi.sormas.doa.DbConnector"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.mirabilia.org.hzi.sormas.doa.ConffileCatcher"%>

<!DOCTYPE html>
<html lang="en">
    <jsp:include page="template/head.jsp"></jsp:include>

        <body class="sidebar-mini layout-fixed layout-navbar-fixed layout-footer-fixed control-sidebar-slide-open accent-purple">
            <div class="wrapper">
            <jsp:include page="template/nav.jsp"></jsp:include>
            <jsp:include page="template/aside.jsp"></jsp:include>

                <style>
                    #overlay {
                        position: fixed; display: none; width: 100%; height: 100%;
                        top: 0; left: 0; right: 0; bottom: 0;
                        background-color: rgba(0,0,0,0.5); z-index: 2; cursor: pointer;
                    }
                    #text {
                        position: absolute; top: 50%; left: 50%; font-size: 50px;
                        color: white; transform: translate(-50%,-50%); -ms-transform: translate(-50%,-50%);
                    }
                    .lds-facebook { display: inline-block; position: relative; width: 80px; height: 80px; }
                    .lds-facebook div {
                        display: inline-block; position: absolute; left: 8px; width: 16px;
                        background: #28a745; animation: lds-facebook 1.2s cubic-bezier(0, 0.5, 0.5, 1) infinite;
                    }
                    .lds-facebook div:nth-child(1) { left: 8px;  animation-delay: -0.24s; }
                    .lds-facebook div:nth-child(2) { left: 32px; animation-delay: -0.12s; }
                    .lds-facebook div:nth-child(3) { left: 56px; animation-delay: 0; }
                    @keyframes lds-facebook {
                        0%       { top: 8px;  height: 64px; }
                        50%, 100%{ top: 24px; height: 32px; }
                    }
                    .form-label { font-weight: 600; }
                    #resultCard { display: none; }
                    .indicator-box {
                        border: 1px solid #dee2e6; border-radius: 6px;
                        padding: 16px; text-align: center; background: #f8f9fa;
                    }
                    .indicator-box .val { font-size: 2rem; font-weight: 700; }
                    .indicator-box .lbl { font-size: 0.85rem; color: #6c757d; }
                </style>

                <div class="content-wrapper">
                    <section class="content-header">
                        <div class="container-fluid">
                            <div class="row mb-2">
                                <div class="col-sm-6"><h2>Generate SODIT Report</h2></div>
                                <div class="col-sm-6">
                                    <ol class="breadcrumb float-sm-right">
                                        <li class="breadcrumb-item"><a href="#">Home</a></li>
                                        <li class="breadcrumb-item active">Generate Report</li>
                                    </ol>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="col-lg-12 connectedSortable">
                        <div class="row">
                            <section class="col-lg-12 connectedSortable">
                                <div class="card card-default">
                                    <div class="card-header">
                                        <h3 class="card-title"><i class="fas fa-file"></i> Report Generator</h3>
                                    </div>
                                    <div class="card-body">
                                        <form id="reportForm" onsubmit="event.preventDefault(); generateReport();">
                                            <div class="row">
                                                <!-- LEFT COLUMN -->
                                                <div class="col-lg-5 col-md-6">
                                                    <div class="form-group">
                                                        <label class="form-label">Select Report</label>
                                                        <select id="diseaseSelect" name="disease" class="form-control">
                                                            <option value="">Loading diseases...</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Select Year</label>
                                                        <select id="yearSelect" name="year" class="form-control">
                                                            <option value="">Loading years...</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Select Epi Week</label>
                                                        <select id="epiWeekSelect" name="epi_week" class="form-control">
                                                            <option value="">-- Select Epi Week --</option>
                                                        </select>
                                                    </div>
                                                    <div class="w-100 d-flex flex-row justify-content-center mt-3">
                                                        <div style="display:none;" class="lds-facebook"><div></div><div></div><div></div></div>
                                                    </div>
                                                    <div class="w-100 d-flex flex-row justify-content-center mt-2">
                                                        <button id="generateBtn" type="submit" class="btn btn-success btn-flat px-4">
                                                            Generate &amp; Send to DHIS2
                                                        </button>
                                                    </div>
                                                </div>

                                                <!-- RIGHT COLUMN -->
                                                <div class="col-lg-5 col-md-6 offset-lg-1">
                                                    <div class="form-group">
                                                        <label class="form-label">Select Region</label>
                                                        <select id="regionSelect" name="region_id" class="form-control">
                                                            <option value="">Loading regions...</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Select District</label>
                                                        <select id="districtSelect" name="district_id" class="form-control">
                                                            <option value="">-- Select District --</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Select Sub District</label>
                                                        <select id="communitySelect" name="community_id" class="form-control">
                                                            <option value="">-- Select Sub District --</option>
                                                        </select>
                                                    </div>
                                                    <div class="form-group">
                                                        <label class="form-label">Select Facility</label>
                                                        <select id="facilitySelect" name="facility_id" class="form-control">
                                                            <option value="">-- Select Facility --</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>

                                <!-- RESULT CARD -->
                                <div class="card card-default" id="resultCard">
                                    <div class="card-header">
                                        <h3 class="card-title"><i class="fas fa-chart-bar"></i> Report Result</h3>
                                        <div class="card-tools">
                                            <span id="resultMeta" class="badge badge-success" style="font-size:0.9rem;"></span>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-dark" id="res_total">0</div>
                                                    <div class="lbl">Total Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-warning" id="res_suspect">0</div>
                                                    <div class="lbl">Suspect Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-info" id="res_probable">0</div>
                                                    <div class="lbl">Probable Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-primary" id="res_confirmed">0</div>
                                                    <div class="lbl">Confirmed Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-secondary" id="res_not_classified">0</div>
                                                    <div class="lbl">Not Classified</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-success" id="res_positive">0</div>
                                                    <div class="lbl">Positive Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val text-danger" id="res_deaths">0</div>
                                                    <div class="lbl">Deaths</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val" style="color:#007bff;" id="res_male">0</div>
                                                    <div class="lbl">Male Cases</div>
                                                </div>
                                            </div>
                                            <div class="col-6 col-md-3 mb-3">
                                                <div class="indicator-box">
                                                    <div class="val" style="color:#e83e8c;" id="res_female">0</div>
                                                    <div class="lbl">Female Cases</div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row mt-2">
                                            <div class="col-12">
                                                <pre id="resultJson" class="bg-light p-3 rounded" style="font-size:0.85rem; max-height:300px; overflow:auto;"></pre>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </section>
                        </div>
                    </section>
                </div>

                <div id="overlay" onclick="off()">
                    <div id="text"><h2>please wait...</h2></div>
                </div>

            <jsp:include page="template/scripts_footer.jsp"></jsp:include>

            <script>
                var API = "http://" + window.location.hostname + ":5000/api";

                // ── Bootstrap dropdowns ──────────────────────────────────────────
                function loadDiseases() {
                    $.get(API + "/diseases", function(data) {
                        var opts = '<option value="">-- Select Report --</option>';
                        data.forEach(function(d) {
                            opts += '<option value="' + d.value + '">' + d.label + ' report</option>';
                        });
                        $("#diseaseSelect").html(opts);
                    });
                }

                function loadYears() {
                    $.get(API + "/years", function(data) {
                        var currentYear = new Date().getFullYear();
                        var opts = '<option value="">-- Select Year --</option>';
                        data.slice().reverse().forEach(function(y) {
                            opts += '<option value="' + y + '"' + (y === currentYear ? ' selected' : '') + '>' + y + '</option>';
                        });
                        $("#yearSelect").html(opts);
                        buildEpiWeeks(currentYear);
                    });
                }

                function buildEpiWeeks(year) {
                    // ISO weeks: determine max week for the year
                    var dec28 = new Date(year, 11, 28);
                    var maxWeek = getISOWeek(dec28);
                    var opts = '<option value="">-- Select Epi Week --</option>';
                    for (var w = 1; w <= maxWeek; w++) {
                        opts += '<option value="' + w + '">Week ' + w + '</option>';
                    }
                    $("#epiWeekSelect").html(opts);
                }

                function getISOWeek(d) {
                    var date = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
                    date.setUTCDate(date.getUTCDate() + 4 - (date.getUTCDay() || 7));
                    var yearStart = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
                    return Math.ceil((((date - yearStart) / 86400000) + 1) / 7);
                }

                function loadRegions() {
                    $.get(API + "/regions", function(data) {
                        var opts = '<option value="">-- All Regions --</option>';
                        data.forEach(function(r) {
                            opts += '<option value="' + r.id + '">' + r.name + '</option>';
                        });
                        $("#regionSelect").html(opts);
                    });
                }

                // ── Cascading selects ────────────────────────────────────────────
                $("#yearSelect").on("change", function() {
                    var y = parseInt($(this).val()) || new Date().getFullYear();
                    buildEpiWeeks(y);
                });

                $("#regionSelect").on("change", function() {
                    var rid = $(this).val();
                    $("#districtSelect").html('<option value="">-- Select District --</option>');
                    $("#communitySelect").html('<option value="">-- Select Sub District --</option>');
                    $("#facilitySelect").html('<option value="">-- Select Facility --</option>');
                    if (!rid) return;
                    $.get(API + "/districts", { region_id: rid }, function(data) {
                        var opts = '<option value="">-- All Districts --</option>';
                        data.forEach(function(d) { opts += '<option value="' + d.id + '">' + d.name + '</option>'; });
                        $("#districtSelect").html(opts);
                    });
                });

                $("#districtSelect").on("change", function() {
                    var did = $(this).val();
                    $("#communitySelect").html('<option value="">-- Select Sub District --</option>');
                    $("#facilitySelect").html('<option value="">-- Select Facility --</option>');
                    if (!did) return;
                    $.get(API + "/communities", { district_id: did }, function(data) {
                        var opts = '<option value="">-- All Sub Districts --</option>';
                        data.forEach(function(c) { opts += '<option value="' + c.id + '">' + c.name + '</option>'; });
                        $("#communitySelect").html(opts);
                    });
                    $.get(API + "/facilities", { district_id: did }, function(data) {
                        var opts = '<option value="">-- All Facilities --</option>';
                        data.forEach(function(f) { opts += '<option value="' + f.id + '">' + f.name + '</option>'; });
                        $("#facilitySelect").html(opts);
                    });
                });

                $("#communitySelect").on("change", function() {
                    var cid = $(this).val();
                    $("#facilitySelect").html('<option value="">-- Select Facility --</option>');
                    if (!cid) return;
                    $.get(API + "/facilities", { community_id: cid }, function(data) {
                        var opts = '<option value="">-- All Facilities --</option>';
                        data.forEach(function(f) { opts += '<option value="' + f.id + '">' + f.name + '</option>'; });
                        $("#facilitySelect").html(opts);
                    });
                });

                // ── Generate report ──────────────────────────────────────────────
                function generateReport() {
                    var disease    = $("#diseaseSelect").val();
                    var year       = $("#yearSelect").val();
                    var epi_week   = $("#epiWeekSelect").val();
                    var region_id  = $("#regionSelect").val() || null;
                    var district_id= $("#districtSelect").val() || null;
                    var community_id=$("#communitySelect").val() || null;
                    var facility_id= $("#facilitySelect").val() || null;

                    if (!disease || !year || !epi_week) {
                        Swal.fire("Validation", "Please select Report, Year and Epi Week.", "warning");
                        return;
                    }

                    $(".lds-facebook").show();
                    $("#generateBtn").prop("disabled", true);

                    $.ajax({
                        type: "POST",
                        url: API + "/report",
                        contentType: "application/json",
                        data: JSON.stringify({
                            disease: disease, year: parseInt(year),
                            epi_week: parseInt(epi_week),
                            region_id: region_id, district_id: district_id,
                            community_id: community_id, facility_id: facility_id
                        }),
                        success: function(r) {
                            $(".lds-facebook").hide();
                            $("#generateBtn").prop("disabled", false);

                            $("#res_total").text(r.indicators.total_cases);
                            $("#res_suspect").text(r.indicators.suspect_cases);
                            $("#res_probable").text(r.indicators.probable_cases);
                            $("#res_confirmed").text(r.indicators.confirmed_cases);
                            $("#res_not_classified").text(r.indicators.not_classified_cases);
                            $("#res_positive").text(r.indicators.positive_cases);
                            $("#res_deaths").text(r.indicators.deaths);
                            $("#res_male").text(r.indicators.male_cases);
                            $("#res_female").text(r.indicators.female_cases);

                            var locParts = [];
                            if (r.location.region)       locParts.push(r.location.region);
                            if (r.location.district)     locParts.push(r.location.district);
                            if (r.location.sub_district) locParts.push(r.location.sub_district);
                            if (r.location.facility)     locParts.push(r.location.facility);
                            var locStr = locParts.length ? locParts.join(" › ") : "National";

                            $("#resultMeta").text(r.disease + " | Week " + r.epi_week + " " + r.year + " | " + locStr);
                            $("#resultJson").text(JSON.stringify(r, null, 2));
                            $("#resultCard").show();

                            var d = r.dhis2 || {};
                            var ic = d.importCount || {};
                            if (d.status === "ERROR") {
                                Swal.fire("DHIS2 Push Failed", d.message || JSON.stringify(d), "error");
                            } else {
                                Swal.fire({
                                    title: "Report sent to DHIS2",
                                    icon: "success",
                                    html: "<div class='d-flex justify-content-around'>" +
                                          "<div><h2><b>" + (ic.imported||0) + "</b></h2><small>Imported</small></div>" +
                                          "<div><h2><b>" + (ic.updated||0)  + "</b></h2><small>Updated</small></div>" +
                                          "<div><h2><b>" + (ic.ignored||0)  + "</b></h2><small>Ignored</small></div>" +
                                          "<div><h2><b>" + (ic.deleted||0)  + "</b></h2><small>Deleted</small></div>" +
                                          "</div>"
                                });
                            }
                        },
                        error: function() {
                            $(".lds-facebook").hide();
                            $("#generateBtn").prop("disabled", false);
                            Swal.fire("Error", "Failed to generate report. Please try again.", "error");
                        }
                    });
                }

                function off() { document.getElementById("overlay").style.display = "none"; }

                // ── Init ─────────────────────────────────────────────────────────
                $(document).ready(function() {
                    loadDiseases();
                    loadYears();
                    loadRegions();
                });
            </script>
    </body>
</html>
