const std = @import("std");
const GeneralPurposeAllocator = std.heap.GeneralPurposeAllocator;
const print = std.debug.print;

// const regex = @import("regex");
const http = @import("http.zig");
const Request = http.Request;
const Response = http.Response;
const Server = http.Server;
const routes = @import("routes.zig");
const Handler = http.server.Handler;
const RouteHandler = routes.RouteHandler;
const RouteHandlerFn = routes.RouteHandlerFn;
const Router = routes.Router;
const middlewares = @import("middlewares.zig");
const LogRequest = middlewares.LogRequest;

pub const io_mode = .evented;

pub fn main() anyerror!void {
    var gpa = GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const handler = comptime Router(&.{ RouteHandlerFn("/", LogRequest(indexHandler)), RouteHandler("/greet/:name", Handler.init(greetHandler)) });

    var server = Server(handler).init(
        allocator,
        .{
            .address = "127.0.0.1",
            .port = 8080,
        },
    );

    try server.listen();
}
fn greetHandler(req: *Request, resp: *Response) anyerror!void {
    try resp.respond(Response.Status.Ok(), null, req.getQueryParam("name").?);
}
fn indexHandler(_: *Request, resp: *Response) anyerror!void {
    try resp.respond(Response.Status.Ok(), null, "index");
}
