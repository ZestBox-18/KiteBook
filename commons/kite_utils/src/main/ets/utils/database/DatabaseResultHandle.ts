import { relationalStore } from "@kit.ArkData";

export function resultSet2Record(resultSet: relationalStore.ResultSet): Record<string, any>[] {
  let res: Record<string, any>[] = []
  resultSet.goToFirstRow()
  for (let index = 0; index < resultSet.rowCount; index++) {
    res.push(resultSet.getRow() as Record<string, any>)
    resultSet.goToNextRow()
  }
  return res
}