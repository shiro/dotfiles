import {MutationResolvers} from "@server/resolvers/resolverTypes";
import {UnauthenticatedError} from "@core/Errors/generalErrors";


export const {{ name }}Mutation: MutationResolvers["{{ name }}"] = async (parent, args, ctx) => {
    if (!ctx.isAuthenticated()) throw new UnauthenticatedError();

    return {} as any;
}
