/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.web.data;

//~--- non-JDK imports --------------------------------------------------------

import digital.survey.model.ISurveyService;
import digital.survey.model.SurveyAudienceMember;
import guru.mmp.application.web.WebApplicationException;
import guru.mmp.application.web.data.InjectableDataProvider;
import guru.mmp.common.util.StringUtil;
import org.apache.wicket.model.IModel;

import javax.inject.Inject;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>FilteredSurveyAudienceMemberDataProvider</code> class provides an
 * <code>IDataProvider</code> implementation that retrieves <code>SurveyAudienceMember</code>
 * instances from the database.
 *
 * @author Marcus Portmann
 */
public class FilteredSurveyAudienceMemberDataProvider
    extends InjectableDataProvider<SurveyAudienceMember>
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience the
   * survey audience members are associated with.
   */
  private UUID surveyAudienceId;

  /* Survey Service */
  @Inject
  private ISurveyService surveyService;

  /**
   * The filter used to limit the matching survey audiences.
   */
  private String filter;

  /**
   * Constructs a new <code>FilteredSurveyAudienceMemberDataProvider</code>.
   * <p/>
   * Hidden default constructor to support CDI.
   */
  @SuppressWarnings("unused")
  protected FilteredSurveyAudienceMemberDataProvider() {}

  /**
   * Constructs a new <code>FilteredSurveyAudienceMemberDataProvider</code>.
   *
   * @param surveyAudienceId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey audience the survey audience members are associated with
   */
  public FilteredSurveyAudienceMemberDataProvider(UUID surveyAudienceId)
  {
    this.surveyAudienceId = surveyAudienceId;
  }

  /**
   * @see org.apache.wicket.model.IDetachable#detach()
   */
  public void detach() {}

  /**
   * Returns the filter used to limit the matching survey audiences.
   *
   * @return the filter used to limit the matching survey audiences
   */
  @SuppressWarnings("unused")
  public String getFilter()
  {
    return filter;
  }

  /**
   * Retrieves the matching survey audience members from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>.
   *
   * @param first the index of the first entry to return
   * @param count the number of the entries to return
   *
   * @return the survey audience members retrieved from the database starting with
   * index <code>first</code> and ending with <code>first+count</code>
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#iterator(long, long)
   */
  public Iterator<SurveyAudienceMember> iterator(long first, long count)
  {
    try
    {
      List<SurveyAudienceMember> allSurveyAudienceMembers = StringUtil.isNullOrEmpty(filter)
          ? surveyService.getMembersForSurveyAudience(surveyAudienceId)
          : surveyService.getFilteredMembersForSurveyAudience(surveyAudienceId, filter);

      return allSurveyAudienceMembers.subList((int) first, (int) Math.min(first + count,
          allSurveyAudienceMembers.size())).iterator();
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to load the survey audience members for the survey audience (%s)"
          + " matching the filter (%s) from index (%d) to (%d)", surveyAudienceId, filter, first,
          first + count - 1), e);
    }
  }

  /**
   * Wraps the retrieved <code>SurveyAudienceMember</code> POJO with a Wicket model.
   *
   * @param surveyAudienceMember the <code>SurveyAudienceMember</code> instance to wrap
   *
   * @return the Wicket model wrapping the <code>SurveyAudienceMember</code> instance
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#model(java.lang.Object)
   */
  public IModel<SurveyAudienceMember> model(SurveyAudienceMember surveyAudienceMember)
  {
    return new DetachableSurveyAudienceMemberModel(surveyAudienceMember);
  }

  /**
   * Set the filter used to limit the matching survey audiences.
   *
   * @param filter the filter used to limit the matching survey audiences
   */
  public void setFilter(String filter)
  {
    this.filter = filter;
  }

  /**
   * Returns the total number of survey audience members.
   *
   * @return the total number of survey audience members
   *
   * @see org.apache.wicket.markup.repeater.data.IDataProvider#size()
   */
  public long size()
  {
    try
    {
      return StringUtil.isNullOrEmpty(filter)
          ? surveyService.getNumberOfMembersForSurveyAudience(surveyAudienceId)
          : surveyService.getNumberOfFilteredMembersForSurveyAudience(surveyAudienceId, filter);
    }
    catch (Throwable e)
    {
      throw new WebApplicationException(String.format(
          "Failed to retrieve the number of survey audience members for the survey audience (%s)"
          + " matching the filter (%s)", surveyAudienceId, filter), e);
    }
  }
}
