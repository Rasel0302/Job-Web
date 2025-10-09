import mysql from 'mysql2/promise';
export declare const createConnection: () => Promise<mysql.Connection>;
export declare const getConnection: () => mysql.Connection;
export declare const closeConnection: () => Promise<void>;
//# sourceMappingURL=database.d.ts.map