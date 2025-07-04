<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Chained Select Example</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/include/libs/jquery-chained/2.0.0-beta.2/jquery.chained.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        select {
            width: 200px;
            padding: 5px;
        }
    </style>
    <script>
        $(document).ready(function() {
            $("#state").chained("#country");
        });
    </script>
</head>
<body>

<h2>Country and State Form</h2>

<form method="post" action="account_info.cfm">
    <div class="form-group">
        <label for="country">Country:</label>
        <select id="country" name="country">
            <option value="">Select a country</option>
            <option value="usa">USA</option>
            <option value="canada">Canada</option>
        </select>
    </div>

    <div class="form-group">
        <label for="state">State:</label>
        <select id="state" name="state">
            <option value="">Select a state</option>
            <option value="california" class="usa">California</option>
            <option value="texas" class="usa">Texas</option>
            <option value="ontario" class="canada">Ontario</option>
            <option value="quebec" class="canada">Quebec</option>
        </select>
    </div>

    <div class="form-group">
        <button type="submit">Submit</button>
    </div>
</form>

</body>
</html>
