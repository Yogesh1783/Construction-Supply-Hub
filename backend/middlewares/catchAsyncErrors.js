export default (ControllerFunction)=>(req,res,next)=>
    Promise.resolve(ControllerFunction(req,res,next)).catch(next);