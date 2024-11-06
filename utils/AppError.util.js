class AppError extends Error {
    constructor(message,statuscode){
        super(message);
        this.statusCode = statuscode;
        this.explanation = message;
    }
}

module.exports = AppError