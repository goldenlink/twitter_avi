
/**
* text counting function to display the remaining character count.
*/
function textCounter(textarea, countdown, maxlimit)
{
  textareaid = document.getElementById(textarea);
  if (textareaid.value.length > maxlimit)
    textareaid.value = textareaid.value.substring(0, maxlimit);
  else
    document.getElementById(countdown).value = '('+(maxlimit-textareaid.value.length)+' characters available)';
}