$(document).ready(()=>{

  // CSV/ZIP Form
  var $csv_form      = $('#csv-upload-form'),
      $f_input_btn   = $('#f-input-btn'),
      $f_input       = $('#f-input'),
      $f_submit      = $('#f-submit'),
      $f_success_msg = $('#success-msg'),
      $f_error_msg   = $('#error-msg'),
      $f_correct_msg = $('#correct-file-msg'),
      $f_invalid_msg = $('#invalid-file-msg');

  // ZIP Form (Under Instructor's Dashboard)
  var $zip_form       = $('#zip-upload-form'),
      $zip_f_input    = $('#zip-f-input');

  //If user clicks upload, open the form file input window (for CSV or ZIP inputs)
  $f_input_btn.click((e)=>{
    e.preventDefault();
    $f_input.click(); //csv
    $zip_f_input.click(); //zip
  });


  // CSV Input - If user selected a file, validate file (must be csv) and continue
  $f_input.change(()=>{
    let f = $f_input.val();
    /* rehides success/error message and submit button, unless the file is valid/invalid */
    hideMessages();

    //If file was selected a validated
    if(validateCSVFile(f)){
      $('#correct-file-msg>span').text(trimFileName(f));
      $f_correct_msg.slideDown(500);
      $f_submit.delay(500).slideDown(500);
    }  else {
      $f_invalid_msg.slideDown(500);
      $f_input.val('');
    }
  });


  // ZIP Input - If user selected a file, validate file (must be ZIP) and continue
  $zip_f_input.change(()=>{
    let f = $zip_f_input.val();
    /* rehides success/error message and submit button, unless the file is valid/invalid */
    hideMessages();

    //If file was selected a validated
    if(validateZIPFile(f)){
      $('#correct-file-msg>span').text(trimFileName(f));
      $f_correct_msg.slideDown(500);
      $f_submit.delay(500).slideDown(500);
    }  else {
      $f_invalid_msg.slideDown(500);
      $zip_f_input.val('');
    }
  });


  // CSV Form
  //If user submits file, validate input file
  $csv_form.submit((e)=>{
    e.stopPropagation();
    e.preventDefault();
    // Validate again to be safe... (In case user unhides this submit button from css file)
    if(validateCSVFile($f_input.val())){
      // Run ajax call:
      let form = $csv_form[0];
      let formData = new FormData(form);

      $.ajax({
        type: 'POST',
        url: '/',
        data: formData,
        contentType: false,
        processData: false,
        beforeSend: function() {
          hideMessages();
          $('#loader').fadeIn(250);
        },
        complete: function() {
          $('#loader').fadeOut(250);
        },
        success: function(data){
          $f_submit.hide();
          $f_correct_msg.hide();
          if(data === 'true'){
            $f_success_msg.slideDown(500);
          } else {
            $f_error_msg.slideDown(500);
          }
        }
      });
    }
  });

  // Websites ZIP Form
  // If user submits file, validate input file
  $zip_form.submit((e)=>{
    e.stopPropagation();
    e.preventDefault();
    // Validate again to be safe... (In case user unhides this submit button from css file)
    if(validateZIPFile($zip_f_input.val())){
      // Run ajax call:
      let form = $zip_form[0];
      let formData = new FormData(form);

      $.ajax({
        type: 'POST',
        url: '/instructor-dashboard',
        data: formData,
        contentType: false,
        processData: false,
        beforeSend: function() {
          hideMessages();
          $('#loader').fadeIn(250);
        },
        complete: function() {
          $('#loader').fadeOut(250);
        },
        success: function(data){
          $f_submit.hide();
          $f_correct_msg.hide();
          if(data === 'true'){
            $f_success_msg.slideDown(500);
            loadSites();
          } else {
            $f_error_msg.slideDown(500);
          }
        }
      });
    }
  });



  // Hides all success/error/correct/incorrect file messages
  function hideMessages(){
    $f_success_msg.hide();
    $f_error_msg.hide();
    $f_correct_msg.hide();
    $f_invalid_msg.hide();
    $f_submit.hide();
  }

  //Trims the file name
  function trimFileName(fname){
    for(let i=fname.length; i>0; i--){
      if(fname[i] === '\\'){
        return fname.slice(i+1);
      }
    }
    return false;
  }

  //Returns true if it is a csv file
  function validateCSVFile(fname){
    return fname.endsWith('.csv');  
  }

  //Returns true if it is a zip file
  function validateZIPFile(fname){
    return fname.endsWith('.zip');  
  }

});
