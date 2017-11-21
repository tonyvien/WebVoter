$(document).ready(()=>{

  var $csv_form      = $('#csv-upload-form'),
      $f_input_btn   = $('#f-input-btn'),
      $f_input       = $('#f-input'),
      $f_submit      = $('#f-submit'),
      $f_success_msg = $('#success-msg'),
      $f_error_msg   = $('#error-msg'),
      $f_correct_msg = $('#correct-file-msg'),
      $f_invalid_msg = $('#invalid-file-msg');

  //If user clicks upload, open the form file input window
  $f_input_btn.click((e)=>{
    e.preventDefault();
    $f_input.click();
  });


  //If user selected a file, validate file (must be csv) and continue
  $f_input.change(()=>{
    let f = $f_input.val();
    /* rehides success/error message and submit button, unless the file is valid/invalid */
    hideMessages();

    //If file was selected a validated
    if(validateFile(f)){
      $('#correct-file-msg>span').text(trimFileName(f));
      $f_correct_msg.slideDown(500);
      $f_submit.delay(500).slideDown(500);
    }  else {
      $f_invalid_msg.slideDown(500);
      $f_input.val('');
    }
  });


  //If user submits file, validate input file
  $csv_form.submit((e)=>{
    e.stopPropagation();
    e.preventDefault();
    // Validate again to be safe... (In case user unhides this submit button from css file)
    if(validateFile($f_input.val())){
      // Run ajax call:
      let form = $csv_form[0];
      let formData = new FormData(form);

      $.ajax({
        type: 'POST',
        url: '/',
        data: formData,
        contentType: false,
        processData: false,
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
  function validateFile(fname){
    return fname.endsWith('.csv');  
  }

});
