 
document.addEventListener('DOMContentLoaded', (event) => {
  console.log('DOMContentLoaded fired'); // Debugging: Verify that DOMContentLoaded is firing

  // Fetch all edit mode toggle buttons
  const editModeButtons = document.querySelectorAll(".toggle_edit_mode");
  
  console.log('Edit Mode Buttons:', editModeButtons); // Debugging: Print out the NodeList of buttons

  // Loop through each button to attach a click event listener
  editModeButtons.forEach((button) => {
    button.addEventListener("click", function(e){
      e.preventDefault(); // Prevent the default behavior of the button
      
      console.log('Button clicked:', e.currentTarget); // Debugging: Print out which button was clicked
      
      // Fetch the card ID from the button's data-card-id attribute
      const cardId = e.currentTarget.dataset.cardId;
      
      console.log('Card ID:', cardId); // Debugging: Print out the card ID

      // Fetch all edit icons within the same card using the card ID
      const editIcons = document.querySelectorAll(`span[data-card-id="${cardId}"]`);
      
      console.log('Edit Icons:', editIcons); // Debugging: Print out the NodeList of matching edit icons

      // Loop through each edit icon to toggle the hide-edit-icon class
      editIcons.forEach((icon) => {
        icon.classList.toggle("hide-edit-icon");
      });
    });
  });
});