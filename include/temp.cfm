<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Remove Button</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@mdi/font/css/materialdesignicons.min.css">
    <style>
        .remove-btn {
            display: flex;
            align-items: center;
            background-color: #f5f5f5;
            border: none;
            padding: 8px 12px;
            font-size: 16px;
            cursor: pointer;
            border-radius: 4px;
        }

        .remove-btn:hover {
            background-color: #e0e0e0;
        }

        .remove-btn .mdi {
            font-size: 20px;
            margin-right: 8px;
            color: #d32f2f; /* Red tone for visibility */
        }
    </style>
</head>
<body>

    <button class="remove-btn" onclick="removeAssociation()">
        <span class="mdi mdi-minus-circle"></span> Remove Link
    </button>

    <script>
        function removeAssociation() {
            alert("Association removed!");
            // Here you can add an AJAX call to remove the association
        }
    </script>

</body>
</html>
