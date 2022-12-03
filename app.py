from flask import Flask, render_template, request, session, redirect
from cs50 import SQL
from flask_session import Session

app = Flask(__name__)


# # Configure database
mainDB = SQL("mysql://root:158502@localhost:3306/assignment2")
userDB = SQL("mysql://root:158502@localhost:3306/User")


# Configure session
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)



@app.route("/")
def index():
    if not session.get("user"):
        return redirect("/login")
    return render_template("index.html")



# BEGIN: Authentication
def userAuth():
    users = userDB.execute("SELECT * FROM User")
    
    for user in users:
        if session["user"] == user["username"] and session["pwd"] == user["pwd"]:
            return True
    
    return False

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        session["user"] = request.form.get("user")
        session["pwd"] = request.form.get("pwd")
        if userAuth(): 
            return redirect("/")         
        else:
            session["user"] = None
            return render_template("login.html", userAuth=0)
    return render_template("login.html")


@app.route("/logout")
def logout():
    session["user"] = None
    return redirect("/")
# END: Authentication


# BEGIN: See customer
@app.route("/customer")
def customer():
    customers = mainDB.execute("\
        SELECT id, ssn, name, phone, email, username, point, customer_rank \
        FROM Customer \
        ORDER BY id ASC")
    return render_template("customer.html", customers=customers)

@app.route("/customer/detail")
def customer_detail():
    q = request.args.get("q")
    if q:
        orders = mainDB.execute("\
            SELECT id, order_time, checkin_date, checkout_date, cost, status \
            FROM Room_order \
            WHERE customer_id LIKE ? ORDER BY id ASC", q)
    else:
        orders = []
    return render_template("order_info.html", orders=orders)
# END: See customer


# START: Add Room type   
@app.route("/roomtype", methods=["GET", "POST"])
def roomtype_update():
    supplies = mainDB.execute("SELECT * FROM Supply_type")

    if request.method == "POST":
        name = request.form.get("name")
        area = request.form.get("area")
        maxCap = request.form.get("maxCap")
        bedSizes = request.form.getlist("bedSizes")
        bedNumbers = request.form.getlist("bedNumbers")
        supplyTypes = request.form.getlist("supplyTypes")
        supplyNumbers = request.form.getlist("supplyNumbers")
        desc = request.form.get("desc")

        if name == "":
            name = "NULL"
        if area == "":
            area = None
        if desc == "":
            desc = "DEFAULT"
        for i in range(len(bedNumbers)):
            if bedNumbers[i] == "":
                bedNumbers[i] = "DEFAULT"
        for i in range(len(supplyTypes)):
            if supplyNumbers[i] == "":
                supplyNumbers[i] = "DEFAULT"

        roomTypeID = mainDB.execute("INSERT INTO Room_type (name, area, description, customer_no) VALUES (?, ?, ?, ?);", name, area, desc, maxCap)


        for i in range(len(bedSizes)):
            mainDB.execute("INSERT INTO Bed VALUES (?, ?, ?);", roomTypeID, bedSizes[i], bedNumbers[i])

        for i in range(len(supplyTypes)):
            mainDB.execute("INSERT INTO Room_type_supply_type VALUES (?, ?, ?);", roomTypeID, supplyTypes[i], supplyNumbers[i])

        return render_template("roomtype.html", supplies=supplies, isSuccess=1)

    return render_template("roomtype.html", supplies=supplies, isSuccess=0)
# END: Add Room type

# START: Report
# @app.route("/report", methods=["POST", "GET"])
# def report():
#     if request.method == "POST":
#         branch = request.form.get("branch")
#         year = request.form.get("year")

#         reps = mainDB.execute("CALL ThongKeLuotKhach (?, ?, @customer_statistic, @month_no);", branch, year)

#         for rep in reps:
#             app.logger.info(rep["MONTH"])

#         return render_template("report.html", reps=reps)
#     return render_template("report.html")
# END: Report