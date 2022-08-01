import {MutationResolvers} from "@server/resolvers/resolverTypes";
import {requireAuthentication} from "@server/auth/serverAuth";


export const {{ name }}Mutation: MutationResolvers["{{ name }}"] = async (parent, args, ctx) => {
    requireAuthentication(ctx);

    return {} as any;
}
