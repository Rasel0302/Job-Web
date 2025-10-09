import { logger } from '../utils/logger.js';
export const errorHandler = (error, req, res, next) => {
    let { statusCode = 500, message } = error;
    // Log the error
    logger.error('Error occurred:', {
        method: req.method,
        url: req.url,
        statusCode,
        message,
        stack: error.stack,
        body: req.body,
        user: req.user?.id || 'anonymous'
    });
    // Don't leak error details in production
    if (process.env.NODE_ENV === 'production' && statusCode === 500) {
        message = 'Internal server error';
    }
    // Handle specific error types
    if (error.name === 'ValidationError') {
        statusCode = 400;
        message = 'Validation error';
    }
    if (error.name === 'CastError') {
        statusCode = 400;
        message = 'Invalid data format';
    }
    if (error.name === 'JsonWebTokenError') {
        statusCode = 401;
        message = 'Invalid token';
    }
    if (error.name === 'TokenExpiredError') {
        statusCode = 401;
        message = 'Token expired';
    }
    // MySQL specific errors
    if (error.message?.includes('ER_DUP_ENTRY')) {
        statusCode = 409;
        message = 'Resource already exists';
    }
    if (error.message?.includes('ER_NO_REFERENCED_ROW')) {
        statusCode = 400;
        message = 'Referenced resource not found';
    }
    res.status(statusCode).json({
        success: false,
        message,
        ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    });
};
export const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};
